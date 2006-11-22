From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 11:21:58 +0300
Message-ID: <200611221121.59322.dim@openvz.org>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru> <45633EDF.3050309@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@sw.ru>, Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161966AbWKVIXP@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <45633EDF.3050309@fr.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 November 2006 21:01, Daniel Lezcano wrote:
> Kirill Korotaev wrote:
> > Cedric,
> >
> > Dmitry Mishin and Daniel Lezcano are working together on the full
> > network namespace incorporating both needs of OpenVZ and VServer/IBM.
> >
> > Thanks,
> > Kirill
>
> Kirill,
>
> We will need this framework to move the network isolation code to the
> ns_proxy/net_namespace structure. So if Cedric gives us a empty
> framework it is fine, except if someone does not agree with it...
>
>    -- Daniel.
This patch looks acceptable for us.
BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a 
reason, why Cedric force us to make some unnecessary work and move existent 
patchset over his interface.

-- 
Thanks,
Dmitry.
