From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V2 2/5] samples/bpf: Makefile verify LLVM
 compiler avail and bpf target is supported
Date: Tue, 26 Apr 2016 10:28:39 -0700
Message-ID: <20160426172837.GC42777@ast-mbp.thefacebook.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162716.22962.36473.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160426162716.22962.36473.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 06:27:16PM +0200, Jesper Dangaard Brouer wrote:
> Make compiling samples/bpf more user friendly, by detecting if LLVM
> compiler tool 'llc' is available, and also detect if the 'bpf' target
> is available in this version of LLVM.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
