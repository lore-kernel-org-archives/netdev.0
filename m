From: "Graham, David" <david.graham@intel.com>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during
 resume
Date: Wed, 16 Sep 2009 14:06:55 -0700
Message-ID: <4AB1536F.9070205@intel.com>
References: <20090915120538.GA26806@bizet.domek.prywatny>
	<13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
	<20090916014448.GA1070@bizet.domek.prywatny>
Reply-To: david.graham@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090916014448.GA1070@bizet.domek.prywatny>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Karol Lewandowski wrote:
> 
> I can test, or rather -- start testing this tommorow, if this makes
> sense to you.
> 
Yes please Karol, test with 6905b1f1...removed. I will continue testing 
here too on 2.6.31, though I have not had a repro yet. And are you 
performing a standby or hibernate, I want to be sure that I'm resuming 
from the same state.
Thanks.
> Thanks.
> 


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
