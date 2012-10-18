From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v7 00/10] IPC: checkpoint/restore in userspace enhancements
Date: Thu, 18 Oct 2012 05:11:08 -0700
Message-ID: <87a9vk3rqb.fsf@xmission.com>
References: <20121018101543.16036.12221.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com,
	will.deacon@arm.com, dhowells@redhat.com, manfred@colorfullife.com,
	hughd@google.com, jmorris@namei.org, mtk.manpages@gmail.com,
	kosaki.motohiro@jp.fujitsu.com, paulmck@linux.vnet.ibm.com,
	sds@tycho.nsa.gov, devel@openvz.org, a.p.zijlstra@chello.nl,
	cmetcalf@tilera.com, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	eparis@parisplace.org, tglx@linutronix.de,
	jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, casey@schaufler-ca.com,
	"Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121018101543.16036.12221.stgit@localhost.localdomain>
	(Stanislav Kinsbursky's message of "Thu, 18 Oct 2012 14:22:21 +0400")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

You ignored all of my feedback that the first 7 messages of your
patchset are unnecessary.  In particular you did not attempt to focus
your patchset on those operations that are most important.

Upon examination it appears also that the 8th and 9th patches of the
patchset are also unnecessary.  And the 10th patch is just a test of the
previous patches, making the 10th patch unneceesary without the rest.

In net this entire patchset is unnecessary and a waste of your reviewers
time.

Once you have IPC checkpoint and restore working there may be a point to
come back and optimize things.  Please don't come back with any System V
Interprocess Communication patches until you can report how much time
is saved by each and every change.

Eric

