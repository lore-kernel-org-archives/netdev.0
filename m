From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net 0/3] BPF JIT fixes for ARM
Date: Tue, 21 Jul 2015 22:20:12 -0700 (PDT)
Message-ID: <20150721.222012.857420707584092557.davem@davemloft.net>
References: <1437480854-22684-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mgherzan@gmail.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk, ast@plumgrid.com
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437480854-22684-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Tue, 21 Jul 2015 14:14:11 +0200

> These patches are fixing bugs in the ARM JIT and should probably find
> their way to a stable kernel. All 60 test_bpf tests in Linux 4.1 release
> are now passing OK (was 54 out of 60 before).

Series applied, thanks.
