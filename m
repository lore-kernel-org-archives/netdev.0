From: Lee Revell <rlrevell@joe-job.com>
Subject: RE: ipw2100: firmware problem
Date: Fri, 10 Jun 2005 16:26:27 -0400
Message-ID: <1118435188.6423.26.camel@mindpipe>
References: <000f01c56dbf$9b15de90$600cc60a@amer.sykes.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: 'Denis Vlasenko' <vda@ilport.com.ua>,
	'Pavel Machek' <pavel@ucw.cz>,
	'Jeff Garzik' <jgarzik@pobox.com>,
	'Netdev list' <netdev@oss.sgi.com>,
	'kernel list' <linux-kernel@vger.kernel.org>,
	"'James P. Ketrenos'" <ipw2100-admin@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261208AbVFJUZl@vger.kernel.org>
To: abonilla@linuxwireless.org
In-Reply-To: <000f01c56dbf$9b15de90$600cc60a@amer.sykes.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-10 at 07:23 -0600, Alejandro Bonilla wrote:
> >
> > Adding kernel level wireless autoconfiguration duplicates the effort.
> > Since I am not going to give up a requirement to be able to stay radio
> > silent at boot (me too wants freedom, not only you), you need to add
> > disable=1 module parameter to each driver, which adds to the mess.
> >
> > ALSA does the Right Thing. Sound is completely muted out at
> > module load.
> > It's a user freedom to set desired volume level after that.
> 
> Yeah right. I remember I had to google for 10 minutes to find the answer for
> this one. Why would you install something, for it to not work?
> 
> It thing of Mute in ALSA is stupid. If you want Sound, you install the Sound
> and enable it. Why would it make you google for more things to do? ALSA mute
> on install is WAY way, not OK.

It took you 10 minutes of googling before you thought to try the mixer?
Sorry dude, this is PEBKAC.

Lee
