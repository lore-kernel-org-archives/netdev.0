From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V2 3/5] samples/bpf: add a README file to get
 users started
Date: Tue, 26 Apr 2016 10:31:06 -0700
Message-ID: <20160426173105.GD42777@ast-mbp.thefacebook.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162721.22962.25054.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160426162721.22962.25054.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 06:27:22PM +0200, Jesper Dangaard Brouer wrote:
> +
> +Manually compiling LLVM with 'bpf' support
> +------------------------------------------
> +
> +In some LLVM versions the BPF target were marked experimental. They
> +needed the 'cmake .. -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=BPF'.  Since
> +version 3.7.1, LLVM adds a proper LLVM backend target for the BPF
> +bytecode architecture.

it's actually non-experimental since 3.7.0.
It was experimental after 3.6 was released during development of 3.7.
I doubt you can find this anywhere, so I suggest to just drop this paragraph.

