From: Paul Moore <paul.moore@hp.com>
Subject: Re: [redhat-lspp] Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Mon, 26 Jun 2006 22:45:02 -0400
Message-ID: <200606262245.03628.paul.moore@hp.com>
References: <20060621194234.979661000@flek.zko.hp.com> <F5329247-1566-4989-954B-A199240DC89F@nall.com> <Pine.LNX.4.64.0606262031010.26545@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joe Nall <joe@nall.com>, David Miller <davem@davemloft.net>,
	jmorris@redhat.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	RedHat LSPP <redhat-lspp@redhat.com>,
	linux-security-module@vger.kernel.org,
	SELinux List <selinux@tycho.nsa.gov>, netdev@vger.kernel.org,
	Steve Grubb <sgrubb@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606262031010.26545@d.namei>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 June 2006 8:33 pm, James Morris wrote:
> On Mon, 26 Jun 2006, Joe Nall wrote:
> > For all of the EAL4 LSPP Linux evaluation work is being done by Red
> > Hat/IBM/HP/atsec and others to be useful to integrators, there has to be
> > basic (e.g. CIPSO) multilevel network interoperability with existing
> > multilevel systems and good (e.g IPSec) multilevel networking between
> > SELinux systems.
>
> Just to be clear, my understanding is that the native xfrm labeling is
> suitable for LSPP evaluation, as distinct from CIPSO being desired by
> system integrators from an interoperability point of view.
>

True, but I believe the point Joe was trying to make was that providing 
support for only one labeling mechanism would limit the usefulness of the 
evaluated configuration.  What good is a Common Criteria evaluation if it 
doesn't contain the features that user's require?

-- 
paul moore
linux security @ hp
