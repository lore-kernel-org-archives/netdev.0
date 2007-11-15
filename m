From: Bron Gondwana <brong@fastmail.fm>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 15:16:13 +1100
Message-ID: <20071115041613.GC15302__46848.6800128177$1195111046$gmane$org@brong.net>
References: <20071113143201.9441c940.akpm@linux-foundation.org>
	<20071113.175551.131375600.davem@davemloft.net>
	<20071114095507.GA32595@flint.arm.linux.org.uk>
	<20071114.020706.219917088.davem@davemloft.net>
	<473AE010.4090806@keyaccess.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, Takashi Iwai <tiwai@suse.de>,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	alsa-devel@alsa-project.org, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org,
	David Miller <davem@davemloft.net>, Jaroslav Kysela <perex@suse.cz>
To: Rene Herman <rene.herman@keyaccess.nl>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <473AE010.4090806@keyaccess.nl>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 12:46:24PM +0100, Rene Herman wrote:
> On 14-11-07 11:07, David Miller wrote:
>
> Added Jaroslav and Takashi to the already extensive CC....
>
>> From: Russell King <rmk+lkml@arm.linux.org.uk>
>
>>> So, when are you creating a replacement alsa-devel mailing list on
>>> vger?  That's also subscribers-only.
>> The operative term is "alternative" rather than "replacement".
>> Perhaps this misunderstanding is what you're so upset about.
>> And yes, that alsa list bugs the crap out of me too.  I'm more than
>> happy to provide an alternative for that one as well.
>
> alsa-devel@alsa-project.org is not subscriber-only. Same as that arm list, 
> it's _moderated_ for non-subscribers and given that I and other moderators 
> have been doing our best to moderate quickly (I tend to stay logged in to 
> the moderation interface all day for example) what specifically bugged the 
> crap out of you? It's not something a poster needs to concern himself with.

Totally unrelated - I sent something to the kolab mailing list a couple
of days ago (it's moderated for non subscribers) informing them that I
had found the cause of some Cyrus bugs that they had problems with in
the past and providing a link to my post to the cyrus list with the
patches attached.

It sat in the moderation queue and then was rejected with "non
subscriber post to subscription only list".  Not only was the reponse a
day later when I had moved on to other things, but it got me really
pissed off that I had put some effort into providing a good quality post
that outlined the specific issues and how they applied to their project,
and had been summarily dismissed, probably without the effort being put
in.

There's no way for a non-subscriber to know in advance if the list they
are trying to post to will do that to them, completely negating the
effort put in to writing something worthwhile to inform that community.
It's insular, and it sucks.

So yeah, my attitude now is that the Kolab folks can go screw themselves
and track down the fix on their own or wait until I've convinced
upstream to accept the fixes (likely) and they have moved to the new
version (unlikely for a long time, and meanwhile they're missing out on
the performance increases that having a more stable skiplist library 
would give them)

I'm sure if I had something that I considered worth informing the ALSA
project of, I'd be wary of spending the same effort writing a good
post knowing it may be dropped in between the by a list moderator just
selecing all and bouncing them.

Bron.
