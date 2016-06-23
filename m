From: Phil <pme.neratec@gmx.ch>
Subject: Re: rstpd implementation
Date: Thu, 23 Jun 2016 15:56:00 +0200
Message-ID: <576BEA70.6050207@gmx.ch>
References: <576A8873.50809@gmx.ch> <874m8lqfsb.fsf@x220.int.ebiederm.org>
 <20160622111212.249aef89@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160622111212.249aef89@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/22/2016 08:12 PM, Stephen Hemminger wrote:
> On Wed, 22 Jun 2016 12:44:52 -0500
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Phil <pme.neratec@gmx.ch> writes:
>>
>>> Hi,
>>>
>>> When looking for an RSTP daemon I found Stephen Hemminger's
>>> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git
>>> <https://kernel.googlesource.com/pub/scm/linux/kernel/git/shemminger/rstp#zSoyz>
>>> with it's last commit from October 2011.
>>>
>>> Is this implementation still in good use by anybody - or has it been
>>> replaced/superseded by another implementation?
>> I don't know and when you get into user space daemons they aren't much
>> talked about on the kernel lists.  That said you will likely fair better
>> on the netdev list (cc'd).
>>
>> Eric
> The current one I recommend is the MSTPd done by Cumulus
>   https://sourceforge.net/p/mstpd/wiki/Home/
> But like all projects they could use help
>
Thank's a lot to Eric and Stephen for your answers.
In the meantime I also found https://github.com/ocedo/mstpd

Philipp
