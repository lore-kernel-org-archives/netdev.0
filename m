From: Uli Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] wireless-2.6 zd1211rw check against
 regulatory domain rather than hardcoded value of 11
Date: Sun, 29 Oct 2006 16:42:00 +0100
Message-ID: <4544CBC8.5090305@deine-taler.de>
References: <f46018bb0610231121s4fb48f88l28a6e7d4f31d40bb@mail.gmail.com>	
	<453D48E5.8040100@gentoo.org>
	<f46018bb0610240709y203d8cdbw95cdf66db23aa1ce@mail.gmail.com>
	<453E2C9A.7010604@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: holdenk@xandros.com, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	zd1211-devs@lists.sourceforge.net,
	Holden Karau <holden@pigscanfly.ca>
Return-path: <zd1211-devs-bounces@lists.sourceforge.net>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <453E2C9A.7010604@gentoo.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/zd1211-devs>,
	<mailto:zd1211-devs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=zd1211-devs>
List-Post: <mailto:zd1211-devs@lists.sourceforge.net>
List-Help: <mailto:zd1211-devs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/zd1211-devs>,
	<mailto:zd1211-devs-request@lists.sourceforge.net?subject=subscribe>
Sender: zd1211-devs-bounces@lists.sourceforge.net
Errors-To: zd1211-devs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Holden Karau wrote:
>> I've changed the patch based on your suggestions :-)
> 
> Thanks, looks fine. Let's just wait for an OK from Ulrich, then you can 
> send it to John, without broken tabs/lines, with signoff and description.
> 
> Daniel

I'm not so sure about this. This patching might be US-specific and we 
cannot simply apply the setting for top channel of another domain 
instead of channel 11. One option would be to set the value only under 
the US regulatory domain.

Kind regards,

Uli

-- 
Uli Kunitz (kune@deine-taler.de)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
