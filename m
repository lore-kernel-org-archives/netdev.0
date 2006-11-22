From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 16:34:03 +0300
Message-ID: <200611221634.04090.dim@openvz.org>
References: <4563007B.9010202@fr.ibm.com> <200611221121.59322.dim@openvz.org> <m1wt5nub08.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Kirill Korotaev <dev@sw.ru>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:63341 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1755867AbWKVNev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 08:34:51 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1wt5nub08.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 22 November 2006 11:43, Eric W. Biederman wrote:
> Dmitry Mishin <dim@openvz.org> writes:
> 
> > On Tuesday 21 November 2006 21:01, Daniel Lezcano wrote:
> >> Kirill Korotaev wrote:
> >> > Cedric,
> >> >
> >> > Dmitry Mishin and Daniel Lezcano are working together on the full
> >> > network namespace incorporating both needs of OpenVZ and VServer/IBM.
> >> >
> >> > Thanks,
> >> > Kirill
> >>
> >> Kirill,
> >>
> >> We will need this framework to move the network isolation code to the
> >> ns_proxy/net_namespace structure. So if Cedric gives us a empty
> >> framework it is fine, except if someone does not agree with it...
> >>
> >>    -- Daniel.
> > This patch looks acceptable for us.
> > BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a 
> > reason, why Cedric force us to make some unnecessary work and move existent 
> > patchset over his interface.
> 
> If you are going to take that attitude.  Where was this conversation?
> 
> It appears several relevant people were not aware of this development
> discussion.  So when it comes up for general review you can expect your
> approach as well as your code to be critiqued.
Eric, 

please read and comment Daniel's summary:
http://marc.theaimsgroup.com/?l=linux-netdev&m=116352117000763&w=2

Seems, that you missed it.

-- 
Thanks,
Dmitry.
