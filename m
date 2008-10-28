From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 28 Oct 2008 14:51:03 +0100
Message-ID: <490718C7.3010501@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk>	<4903947A.3060206@gmail.com>	<20081025223443.GA30913@electric-eye.fr.zoreil.com>	<4904A7C5.7090801@gmail.com>	<20081026174654.GB24790@electric-eye.fr.zoreil.com>	<4906E4BE.9050304@gmail.com> <m3mygozvd4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753803AbYJ1NvX@vger.kernel.org>
In-Reply-To: <m3mygozvd4.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/2008 02:45 PM, Krzysztof Halasa wrote:
> Jiri Slaby <jirislaby@gmail.com> writes:
> 
>>> Same thing if you unplug the battery ?
>> Thanks, now it seems to be OK.
> 
> Well, perhaps reverting that patch was a bit premature?

No, it helped after reverting that patch. I think we don't want defunct 2.6.28
with these nics.

> If removing battery fixes the problem then it's not the EEPROM.

Agreed.
