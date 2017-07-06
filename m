From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 06/14] bpf: Implement show_options
Date: Thu, 06 Jul 2017 10:00:57 +0200
Message-ID: <595DEE39.9080508@iogearbox.net>
References: <149926824154.20611.6104595541055328700.stgit@warthog.procyon.org.uk> <149926828898.20611.6599036959362646109.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149926828898.20611.6599036959362646109.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/05/2017 05:24 PM, David Howells wrote:
> Implement the show_options superblock op for bpf as part of a bid to get
> rid of s_options and generic_show_options() to make it easier to implement
> a context-based mount where the mount options can be passed individually
> over a file descriptor.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Alexei Starovoitov <ast@kernel.org>
> cc: Daniel Borkmann <daniel@iogearbox.net>
> cc: netdev@vger.kernel.org

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
