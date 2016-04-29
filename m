From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V4 0/5] samples/bpf: Improve user experience
Date: Fri, 29 Apr 2016 14:26:55 -0400 (EDT)
Message-ID: <20160429.142655.123465258723452162.davem@davemloft.net>
References: <20160428121949.16807.84828.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160428121949.16807.84828.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 28 Apr 2016 14:20:48 +0200

> It is a steep learning curve getting started with using the eBPF
> examples in samples/bpf/.  There are several dependencies, and
> specific versions of these dependencies.  Invoking make in the correct
> manor is also slightly obscure.
> 
> This patchset cleanup, document and hopefully improves the first time
> user experience with the eBPF samples directory by auto-detecting
> certain scenarios.
> 
> V4:
>  - Address Naveen's nitpicks
>  - Handle/fail if extra args are passed in LLC or CLANG (David Laight)
> 
> V3:
>  - Add Alexei's ACKs
>  - Remove README paragraph about LLVM experimental BPF target
>    as it only existed between LLVM version 3.6 to 3.7.
> 
> V2:
>  - Adjusted recommend minimum versions to 3.7.1
>  - Included clang build instructions
>  - New patch adding CLANG variable and validation of command

Series applied, thanks Jesper.
