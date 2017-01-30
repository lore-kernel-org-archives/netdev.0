From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next 2/3] lib, traceevent: add PRINT_HEX_STR variant
Date: Mon, 30 Jan 2017 14:01:08 -0500
Message-ID: <20170130140108.502ac6eb@gandalf.local.home>
References: <cover.1485306168.git.daniel@iogearbox.net>
        <001d3f29ee504ab386a6e0b65e885b39cf3d426f.1485306168.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001d3f29ee504ab386a6e0b65e885b39cf3d426f.1485306168.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jan 2017 02:28:17 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Add support for the __print_hex_str() macro that was added for
> tracing, so that user space tools such as perf can understand
> it as well.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---

I haven't tested it, but it looks fine with me:

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve
