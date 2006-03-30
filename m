From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 12:29:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603301228290.13108@bizon.gios.gov.pl>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
 <20060330082441.GA3149@king.bitgnome.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1673170586-1143714576=:13108"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, bb@kernelpanic.ru, mykleb@no.ibm.com,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Mark Nipper <nipsy@bitgnome.net>
In-Reply-To: <20060330082441.GA3149@king.bitgnome.net>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1673170586-1143714576=:13108
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 30 Mar 2006, Mark Nipper wrote:

> On 29 Mar 2006, Brandeburg, Jesse wrote:
>> What I need from you is a reproducible test, and some information.  I
>> have never been able to reproduce this, and I'm trying to isolate the
>> problem a bit.  What motherboards are you using?  What seems to cause
>> this problem?  Are you all using iptables?  Are you all routing? From
>> the reports I assume none of you are using an 82571/2/3 (pci express)
>
>        Unfortunately, my problem machine is a remote, leased
> server, so I'd have to ask my provider for information on the
> motherboard.

You can probably check this with the dmidecode tool.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1673170586-1143714576=:13108--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
