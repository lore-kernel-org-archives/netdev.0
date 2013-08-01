From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] macvlan: validate flags
Date: Thu, 01 Aug 2013 18:36:05 +0400
Message-ID: <51FA7255.1070102@cogentembedded.com>
References: <1375353992-7181-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roprabhu@cisco.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375353992-7181-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01-08-2013 14:48, Michael S. Tsirkin wrote:

> commit df8ef8f3aaa6692970a436204c4429210addb23a

    Please also specify that commit's summary line in parens.
This is the only way to uniquely identify the commit, and it's the requirement 
that came originally from Linus AFAIK.

> added a flags field to macvlan, which can be
> controlled from userspace.
> The idea is to make the interface future-proof
> so we can add flags and not new fields.

> However, flags value isn't validated, as a result,
> userspace can't detect which flags are supported.

> Cc: "David S. Miller" <davem@davemloft.net>
> CC: Roopa Prabhu <roprabhu@cisco.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

WBR, Sergei
