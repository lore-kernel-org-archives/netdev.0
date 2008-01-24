From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/6] PS3: gelic: gelic updates for 2.6.25
Date: Wed, 23 Jan 2008 21:36:17 -0500
Message-ID: <20080124023617.GC3134@tuxdriver.com>
References: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
	<20080122211239.GC3206@tuxdriver.com>
	<1201048834.6807.55.camel@pasglop>
	<20080123005845.GE3206@tuxdriver.com>
	<4796B0AC.5060205@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Geert.Uytterhoeven" <Geert.Uytterhoeven@sonycom.com>,
	Paul Mackerras <paulus@samba.org>,
	Linux/PPC Development <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
To: Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <4796B0AC.5060205@am.sony.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2008 at 07:12:44PM -0800, Geoff Levand wrote:
> On 01/22/2008 04:58 PM, John W. Linville wrote:

> > I thought Geert's had been applied, but I guess I was looking at
> > it wrong.  Is there a powerpc tree that has them?
> 
> Not yet, they are now only in ps3-linux.git.  I sent them out to
> Paul last Friday the 18th for inclusion in 2.6.25.  Here is a link
> to the message:
> 
>   http://ozlabs.org/pipermail/linuxppc-dev/2008-January/050213.html
> 
> > Perhaps 1-6 above
> > and the wireless patch should just be applied to that tree (if there
> > is one) and all merged together?
> 
> I think Paul will accept them if they have the Sign-off-by's of
> the proper network maintainers.

Feel free to add:

	Signed-off-by: John W. Linville <linville@tuxdriver.com>

(Or Acked-by if you would prefer) to the wireless bits.  FWIW, the
wired bits seemed OK to me as well, but I didn't look too closely...

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
