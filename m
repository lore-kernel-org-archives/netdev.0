From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/16] generic hashtable implementation
Date: Tue, 14 Aug 2012 14:16:14 -0400
Message-ID: <20120814181614.GA15099@fieldses.org>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	paul.gortmaker@windriver.com, davem@davemloft.net,
	rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
	aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
	josh@joshtriplett.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
	dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
	teigland@redhat.com, Trond.Myklebust@netapp.com, fweisbec@gmail.com,
	jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com,
	snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org,
	dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2012 at 06:24:34PM +0200, Sasha Levin wrote:
>   SUNRPC/cache: use new hashtable implementation
..
>   lockd: use new hashtable implementation

FWIW, these look fine (and I ran them through some nfs tests and didn't
see any problems).

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
