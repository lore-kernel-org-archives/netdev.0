From: James Morris <jmorris@namei.org>
Subject: Re: [redhat-lspp] Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Mon, 26 Jun 2006 20:33:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606262031010.26545@d.namei>
References: <20060621194234.979661000@flek.zko.hp.com>
 <20060621200031.589235000@flek.zko.hp.com> <20060622.021223.125894633.davem@davemloft.net>
 <F5329247-1566-4989-954B-A199240DC89F@nall.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Paul Moore <paul.moore@hp.com>,
	jmorris@redhat.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	RedHat LSPP <redhat-lspp@redhat.com>,
	linux-security-module@vger.kernel.org,
	SELinux List <selinux@tycho.nsa.gov>, netdev@vger.kernel.org,
	Steve Grubb <sgrubb@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Joe Nall <joe@nall.com>
In-Reply-To: <F5329247-1566-4989-954B-A199240DC89F@nall.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Jun 2006, Joe Nall wrote:

> For all of the EAL4 LSPP Linux evaluation work is being done by Red
> Hat/IBM/HP/atsec and others to be useful to integrators, there has to be basic
> (e.g. CIPSO) multilevel network interoperability with existing multilevel
> systems and good (e.g IPSec) multilevel networking between SELinux systems.

Just to be clear, my understanding is that the native xfrm labeling is 
suitable for LSPP evaluation, as distinct from CIPSO being desired by 
system integrators from an interoperability point of view.



- James
-- 
James Morris
<jmorris@namei.org>
