From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: 25 Sep 2003 21:07:18 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1064516837.995.49.camel@localhost>
References: <Pine.LNX.4.44.0309252151180.11253-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter Devel <netfilter-devel@lists.netfilter.org>,
	Netdev <netdev@oss.sgi.com>, usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309252151180.11253-100000@netcore.fi>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Hi,

> What I fear is that in the end, nothing gets done because having the goal
> set to perfection.  If there is no energy to drive through the
> L3-independent connecting tracking, the end result is that the user does
> not have this feature (remember ip6tables REJECT target?  That must have
> been sitting in netfilter for some 2+ years, and not having been
> integrated in the mainline kernel and the users still do not have the
> feature!).
I have felt the same on Brad Chapman's port. That code has lost in time
:(

> > Your FTP code uses EPSV and EPRT from rfc2428. What's about the FOOBAR
> > RFC (1639)? OK, it's a joke :)
> > Could we open an IPv4 data connection next to the IPv6 controll
> > connection?
> What about LPRT and LPSV?
This is the rfc1639/foobar :)

Regards,

kisza

-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /------------------------------------------->
