From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] test_bpf: add tests checking that JIT/interpreter
 sets A and X to 0.
Date: Mon, 03 Aug 2015 17:03:16 +0200
Message-ID: <55BF82B4.2010701@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-7-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438610528-14245-7-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> It is mandatory for the JIT or interpreter to reset the A and X
> registers to 0 before running the filter. Check that it is the case on
> various ALU and JMP instructions.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
