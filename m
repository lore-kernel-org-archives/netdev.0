From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 00/11] Improve BPF selftests and use the
 library (net-next tree)
Date: Fri, 10 Feb 2017 15:56:57 -0500 (EST)
Message-ID: <20170210.155657.1387470675782545787.davem@davemloft.net>
References: <20170209232145.19085-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, acme@redhat.com,
        daniel@iogearbox.net, wangnan0@huawei.com, netdev@vger.kernel.org
To: mic@digikod.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209232145.19085-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>
Date: Fri, 10 Feb 2017 00:21:34 +0100

> This series brings some fixes to selftests, add the ability to test
> unprivileged BPF programs as root and replace bpf_sys.h with calls to the BPF
> library.
> 
> This is intended for the net-next tree and apply on c0e4dadb3494 ("net: dsa:
> mv88e6xxx: Move forward declaration to where it is needed").

Series applied, thank you.
