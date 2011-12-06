From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Patch is wrong
Date: Tue, 6 Dec 2011 10:10:36 -0200
Message-ID: <20111206101036.1d50e8ac@asterix.rh>
References: <4EDD8B8C.7000905@linux.vnet.ibm.com>
	<20111205.233937.1669740069700653317.davem@davemloft.net>
	<4EDDA413.1080106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxram@us.ibm.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933238Ab1LFMKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 07:10:44 -0500
In-Reply-To: <4EDDA413.1080106@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Dec 2011 13:11:47 +0800
Michael Wang <wangyun@linux.vnet.ibm.com> wrote:

> On 12/06/2011 12:39 PM, David Miller wrote:
> 
> > From: Michael Wang <wangyun@linux.vnet.ibm.com>
> > Date: Tue, 06 Dec 2011 11:27:08 +0800
> > 
> >> I am the author of this patch, and Jeff only change 0, 1 to false
> >> and true, now he become the author.
> > 
> > Take it up with Jeff, I pulled the change from his GIT tree and
> > that's where the authorship information came from.
> > 
> 
> Hi, David
> 
> Jeff know what happened, he promised to add my and Flavio's
> signed-off-by in the pre-mail.
> 
> It's easy to see from the mail that who is the author, and I have
> reply just after Jeff's patch send out to you, I add my signed-off-by
> and From, but no one care.
> 
> I know you are all experts and have lots of patches in community, you
> won't care such a small patch's author, but this is very important for
> me because this is my first patch, it's stand for my passion and will
> to join the community.
> 

Hi Michael,

I think you should be proud of yourself because we worked from
the problem definition, then confirmation of the root cause to
the patch fixing it, which was accepted with a couple of simple
changes. However, it's still basically what we had posted.

I understand your frustration about the author thing (I've been
there). Perhaps this could be an example to sub-tree maintainers
to act more as a coach and always require the submitter to fix
the patch instead of changing it themselves, that is, like Davem
does for net and net-next trees.

Anyway, there are plenty of bugs out there to be fixed and we
will appreciate your help fixing them :)

cheers!
fbl
(sorry the late replies, I was on vacations without e-mail access)
