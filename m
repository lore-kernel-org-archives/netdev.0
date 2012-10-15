From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v6 06/10] glge driver: rename internal SEM_SET macro to
 SEM_INIT
Date: Mon, 15 Oct 2012 19:28:13 +0100
Message-ID: <1350325693.2819.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121015155800.28348.23561.stgit@localhost.localdomain>
	 <20121015160006.28348.79520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <dhowells@redhat.com>,
	<manfred@colorfullife.com>, <hughd@google.com>,
	<jmorris@namei.org>, <mtk.manpages@gmail.com>,
	<kosaki.motohiro@jp.fujitsu.com>, <paulmck@linux.vnet.ibm.com>,
	<sds@tycho.nsa.gov>, <devel@openvz.org>, <a.p.zijlstra@chello.nl>,
	<cmetcalf@tilera.com>, <linux-driver@qlogic.com>,
	<ron.mercer@qlogic.com>, <viro@zeniv.linux.org.uk>,
	<eparis@parisplace.org>, <tglx@linutronix.de>,
	<jitendra.kalsaria@qlogic.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <ebiederm@xmission.com>,
	<casey@schaufler-ca.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121015160006.28348.79520.stgit@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-10-15 at 20:00 +0400, Stanislav Kinsbursky wrote:
> The reason for shit patch is that SET_SET is desired to be a part of new part
> of API of IPC sys_semctl() system call.
[...]

Two spelling errors above. :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

