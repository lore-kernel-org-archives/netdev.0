From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] Increase limit of macvtap queues
Date: Sun, 14 Jun 2015 01:25:30 +0300
Message-ID: <557CADDA.50009@cogentembedded.com>
References: <1434115828-9461-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mst@redhat.com, davem@davemloft.net,
	jasowang@redhat.com, vyasevic@redhat.com,
	bhutchings@solarflare.com, therbert@google.com,
	viro@zeniv.linux.org.uk
To: Pankaj Gupta <pagupta@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434115828-9461-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/12/2015 04:30 PM, Pankaj Gupta wrote:

> Macvtap should be compatible with tuntap for maximum number
> of queues. '1059590254fa9dce9cafc4f07d1103dbec415e76' removes

    Please also specify that commit's summary line in parens.

> the limitation and increases number of queues in tuntap.
> Now, Its safe to increase number of queues in Macvtap as well.

> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>

WBR, Sergei
