From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from
 levon@movementarian.org)
Date: Fri, 26 Sep 2003 07:05:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926070550.3707e3f2.davem@redhat.com>
References: <20030925205530.2a166ccc.davem@redhat.com>
	<200309261348.h8QDm2kT022888@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mitch@sfgoth.com, levon@movementarian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
In-Reply-To: <200309261348.h8QDm2kT022888@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 26 Sep 2003 09:48:03 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> that seems very reasonable.  i believe the following attached patch
> will provide the initial backend interface that mitch's patchset
> depends on (its really just name changes).  mitch, perhaps you could
> just submit this as patch 0/N when you are ready to submit your
> atm_backend changes.

Wait a bit for Linus to suck in the stuff I applied last night,
then you guys can unload the next set of patches on me. :)
