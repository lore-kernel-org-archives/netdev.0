From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.21: known regressions with patches  (for -stable team)
Date: Wed, 02 May 2007 14:09:58 +0200
Message-ID: <46387F96.30409@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: stable@kernel.org, David Miller <davem@davemloft.net>,
	Robert Peterson <rpeterso@redhat.com>,
	James.Bottomley@steeleye.com, linux-scsi@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>, alsa-devel@alsa-project.org,
	perex@suse.cz, Markus Rechberger <markus.rechberger@amd.com>,
	CIJOML <cijoml@volny.cz>, david-b@pacbell.net,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Brett Ryland <nappers@gmail.com>,
	Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org,
	Sebastian Kemper <sebastian_ml@gmx.net>,
	Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org,
	Mark Lord <lkml@rtr.ca>, Daniel Walker <dwalker@mvista.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jan Kiszka <jan.kiszka@web.de>,
	=?ISO-8859-2?Q?Rafa=B3_Bilski?= <rafalbilski@interia.pl>,
	Dave Jones <davej@codemonkey.org.uk>, Greg KH <gregkh@suse.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of known regressions with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions


Subject    : 2.6.21: longhaul freq-scaling broken
References : http://lkml.org/lkml/2007/5/1/260
Submitter  : Jan Kiszka <jan.kiszka@web.de>
Patch      : http://git.kernel.org/?p=linux/kernel/git/davej/cpufreq.git;a=commitdiff_plain;h=07844252ffd81ec192a62014bada1016c9703765
Status     : patch available


Subject    : Kernel hang at "kernel: switched to high resolution mode on cpu 0" when 
             either/both of CONFIG_NO_HZ, CONFIG_HIGH_RES_TIMERS is used
References : http://lkml.org/lkml/2007/4/30/464
Submitter  : Mark Lord <lkml@rtr.ca>
Handled-By : Daniel Walker <dwalker@mvista.com>
             Thomas Gleixner <tglx@linutronix.de>
Patch      : http://lkml.org/lkml/2007/4/13/190
Status     : patch was suggested


Subject    : ACPI related kernel panic
References : http://lkml.org/lkml/2007/4/30/193
             http://bugzilla.kernel.org/show_bug.cgi?id=8385
Submitter  : Sebastian Kemper <sebastian_ml@gmx.net>
Patches    : http://bugzilla.kernel.org/attachment.cgi?id=11331&action=view
             http://bugzilla.kernel.org/attachment.cgi?id=11332&action=view
Status     : patches was suggested


Subject    : sis900 oops in 2.6.21.1 after bringing up the network
References : http://lkml.org/lkml/2007/4/29/138
             http://lkml.org/lkml/2007/4/29/151
Patch      : http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=dc5a144991ba803bc8afded105c9db1dea0e57ab
Submitter  : Brett Ryland <nappers@gmail.com>
Status     : patch available


Subject    : reiserfs -- circular locking
References : http://lkml.org/lkml/2007/4/26/648
Submitter  : David Brownell < david-b@pacbell.net >
Handled-By : Jeff Mahoney < jeffm@suse.com >
Patch      : http://lkml.org/lkml/2007/4/27/332
Status     : patch available


Subject    : Oops when changing USB DVB-T adapter
References : http://lkml.org/lkml/2007/3/9/212
             http://lkml.org/lkml/2007/4/5/154
Submitter  : CIJOML <cijoml@volny.cz>
Handled-By : Markus Rechberger < markus.rechberger@amd.com >
Status     : patches available


Subject    : snd_intel8x0: divide error: 0000
References : http://lkml.org/lkml/2007/3/5/252
Submitter  : Michal Piotrowski < michal.k.k.piotrowski@gmail.com >
Handled-By : Takashi Iwai < tiwai@suse.de >
Patch      : http://lkml.org/lkml/2007/4/20/117
Status     : patch available


Subject    : qla2xxx driver no longer works
References : http://lkml.org/lkml/2007/4/16/49
             http://lkml.org/lkml/2007/4/20/224
Submitter  : David Miller < davem@davemloft.net >
             Robert Peterson < rpeterso@redhat.com >
Handled-By : David Miller < davem@davemloft.net >
Patch      : http://lkml.org/lkml/2007/4/16/234
Status     : patch was suggested


Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
