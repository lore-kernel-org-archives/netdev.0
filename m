From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Sun, 26 Feb 2006 23:38:36 +0100
Message-ID: <44022DEC.1070601@gmx.net>
References: <4400FC28.1060705@gmx.net>	 <20060225180353.5908c955@localhost.localdomain>	 <200602260957.04305.woho@woho.de>  <1140966011.22812.2.camel@localhost>	 <1140968831.2934.32.camel@laptopd505.fenrus.org> <1140970427.23375.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, woho@woho.de,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751418AbWBZWik@vger.kernel.org>
To: pomac@vapor.com
In-Reply-To: <1140970427.23375.11.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Kumlien schrieb:
> On Sun, 2006-02-26 at 16:47 +0100, Arjan van de Ven wrote:
> 
>>On Sun, 2006-02-26 at 16:00 +0100, Ian Kumlien wrote:
>>
>>>On Sun, 2006-02-26 at 09:57 +0100, Wolfgang Hoffmann wrote:
>>>
>>>>On Sunday 26 February 2006 03:03, Stephen Hemminger wrote:
>>>>
>>>>>Instead of whining, try this.
>>>>
>>>>I tried and still see the hang.
>>>
>>>I'm at a record 12 hours with that patch.
>>
>>shhh don't jinx it ;)
> 
> 
> Well it died 33 mins later... =)
> 
> I also saw some oddities... portage stopped working, i dunno if this can
> be MSI related or so, else something is trashing memory in a very
> special way =P

Yes, 0.15 causes memory corruption even if MSI is disabled.


Regards,
Carl-Daniel
