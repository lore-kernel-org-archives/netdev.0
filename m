From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Sun, 04 Dec 2011 19:56:29 +0100
Message-ID: <4EDBC25D.50405@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com> <4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com> <4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com> <4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com> <4EDBC05D.8070109@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EDBC05D.8070109@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 12/04/2011 07:47 PM, Wolfgang Zarre wrote:
> Hello Wolfgang,
...
>> Wolfgang, I just sent out v4. Any chance to give this patch a try? It
>> would be best to use a recent kernel version but I could also adapt the
>> patch to your kernel version, 2.6.39, I think!?
> 
> Sorry for my delayed reply, but wasn't earlier possible.
> Yes, of course, as long as I have the hardware available I can do some
> tests, even
> on a recent kernel due the fact having the project so far completed,
> just another
> test run on the 9th of December.
> 
> Due the flood of emails I lost now track which version You would be
> interested in
> and maybe also which kernel version, so, please let me know and maybe
> were I may
> download the patches.

Well, yes, I was spinning too fast but the patches have been accepted in
the meantime (actually v6 made it). So you just need to clone the most
recent version of Dave's net-next tree.

>> As you are using a CC770 chip, I'm especially interested in the relevant
>> kernel log (dmesg) and "ip -d -s link show".
> 
> Should be not a problem at all.

Great, thanks.

Wolfgang.
