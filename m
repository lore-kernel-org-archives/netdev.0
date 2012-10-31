From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Tue, 30 Oct 2012 21:36:21 -0400
Message-ID: <CA+1xoqd8vAn+N1JuhpXRjSr74OPtnnw_1UBhf8=c4WDC3jOirw@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home> <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu,
	ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
	netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
	dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com,
	Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com,
	jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com,
	snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org,
	dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi Linus,

> But whatever. This series has gotten way too much bike-shedding
> anyway. I think it should just be applied, since it does remove lines
> of code overall. I'd even possibly apply it to mainline, but it seems
> to be against linux-next.

Yup, I switched to using -next because I've been running my
trinity/KVM tools tests with it.

I can either rebase that on top of mainline, or we can ask maintainers
to take it to their own trees if you take only 01/16 into mainline.
What would you prefer?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
