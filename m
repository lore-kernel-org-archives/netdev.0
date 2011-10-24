From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace aware
Date: Sun, 23 Oct 2011 21:27:01 -0700
Message-ID: <m1ehy3j9pm.fsf@fess.ebiederm.org>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
	<1318974898-21431-10-git-send-email-serge@hallyn.com>
	<m1sjmpytpf.fsf@fess.ebiederm.org> <20111020125801.GA1315@hallyn.com>
	<m1fwinvl8u.fsf@fess.ebiederm.org> <20111020141440.GA6201@sergelap>
	<20111024041529.GA23618@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	oleg@redhat.com, richard@nod.at, mikevs@xs4all.net,
	segoon@openwall.com, gregkh@suse.de, dhowells@redhat.com,
	eparis@redhat.com, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111024041529.GA23618@hallyn.com> (Serge E. Hallyn's message of
	"Mon, 24 Oct 2011 04:15:29 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Never mind, it all gets a little convoluted, but I see how it works,
> and - when the time comes - how to do it right for userns.  :)  Sorry
> about that.

No problem.

Eric
