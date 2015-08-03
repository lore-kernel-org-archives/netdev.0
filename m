From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 3/6] test_bpf: test LD_ABS and LD_IND instructions on
 fragmented skbs.
Date: Mon, 03 Aug 2015 17:00:24 +0200
Message-ID: <55BF8208.4070104@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-4-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438610528-14245-4-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> These new tests exercise various load sizes and offsets crossing the
> head/fragment boundary.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
