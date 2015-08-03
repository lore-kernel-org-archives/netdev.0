From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/6] test_bpf: add more tests for LD_ABS and LD_IND.
Date: Mon, 03 Aug 2015 17:02:10 +0200
Message-ID: <55BF8272.8000508@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-6-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438610528-14245-6-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> This exerces the LD_ABS and LD_IND instructions for various sizes and
> alignments. This also checks that X when used as an offset to a
> BPF_IND instruction first in a filter is correctly set to 0.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
