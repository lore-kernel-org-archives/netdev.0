From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Remove unused variable
Date: Thu, 7 Feb 2013 01:23:57 +0300
Message-ID: <20130206222357.GK4937@mwanda>
References: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
 <20130206172234.GB6008@ritirata.org>
 <1360173353.22154.4.camel@debian>
 <20130206195557.GC6008@ritirata.org>
 <1360187945.25903.5.camel@debian>
 <20130206221022.GF6008@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org, Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 lindner_marek-LWAfsSFWpa4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130206221022.GF6008-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Feb 06, 2013 at 11:10:22PM +0100, Antonio Quartulli wrote:
> Hi Emil, 
> 
> On Wed, Feb 06, 2013 at 10:59:05 +0100, Emil Goode wrote:
> > Hi Antonio,
> > 
> > If it is easier I can keep an eye on when the commit lands in the
> > net-next tree and then resend a modified version of the patch.
> > Or do you want me to resend it now?
> > 
> 
> Well, that commit should be merged in net-next after the next merge window.
> 
> You can resend it now, but be sure to CC Stephen Rothwell
> <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> (the linux-next maintainer) and to clearly state that the
> patch is for linux-next.
> 

It doesn't go through Stephen Rothwell.  It goes through Andrew
Morton and it should be CC'd to Sasha Levin.

regards,
dan carpenter
