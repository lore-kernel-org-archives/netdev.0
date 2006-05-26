From: "Mikel L. Matthews" <mikel@argus-systems.com>
Subject: Re: [RFC 0/4] NetLabel
Date: Fri, 26 May 2006 11:20:57 -0500
Message-ID: <44772AE9.1060907@argus-systems.com>
References: <44760E29.4070407@hp.com> <Pine.LNX.4.64.0605251938360.27473@d.namei> <44771EFB.6030203@hp.com> <44772824.6090505@argus-systems.com> <447729B7.4060702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.argus-systems.com ([66.209.209.162]:62973 "EHLO
	ranger.argus-systems.com") by vger.kernel.org with ESMTP
	id S1750994AbWEZQVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 12:21:05 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <447729B7.4060702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same issue, I would drop them.

Paul Moore wrote:
> Mikel L. Matthews wrote:
>> Paul Moore wrote:
>>> James Morris wrote:

>>
> 
> Outgoing fragment *should* be labeled correctly assuming the Linux base
> network stack does the right thing (I haven't tested this yet).  The
> issue we are discussing here is what to do about incoming packets where
> the fragments are not consistently labeled.
> 

-- 
Thanks,
Mike

Mikel L. Matthews
Chief Technology Officer
Innovative Security Systems, Inc.
(dba Argus Systems Group)
1809 Woodfield Dr.
Savoy IL 61874
+1-217-355-6308
www.argus-systems.com
