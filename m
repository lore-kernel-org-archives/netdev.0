From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] Comment sysfs directory tagging
Date: Tue, 04 May 2010 16:03:27 +0200
Message-ID: <4BE0292F.4000007@kernel.org>
References: <20100503212315.GA4141@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>, bcrl@lhnet.ca,
	benjamin.thery@bull.net, cornelia.huck@de.ibm.com,
	eric.dumazet@gmail.com, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:46408 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932078Ab0EDODt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 10:03:49 -0400
In-Reply-To: <20100503212315.GA4141@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/03/2010 11:23 PM, Serge E. Hallyn wrote:
> (against gregkh-2.6)
> 
> Add some in-line comments to explain the new infrastructure, which
> was introduced to support sysfs directory tagging with namespaces.
> I think an overall description someplace might be good too, but it
> didn't really seem to fit into Documentation/filesystems/sysfs.txt,
> which appears more geared toward users, rather than maintainers, of
> sysfs.
> 
> (Tejun, please let me know if I can make anything clearer or failed
> altogether to comment something that should be commented.)

This sure is an improvement but yeah I agree that having an overall
documentation would be great.  If there isn't a matching one, just
create one - sysfs-ns.txt, sysfs-tagged.txt or whatever.

Thanks.

-- 
tejun
