From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: [PATCH] batman-adv: checkpatch cleanup - remove
	lines longer than 80 chars
Date: Wed, 21 Dec 2011 02:59:41 +0800
Message-ID: <201112210259.42387.lindner_marek@yahoo.de>
References: <1324377504-20983-1-git-send-email-lindner_marek@yahoo.de>
	<20111220.133230.713811345652751674.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20111220.133230.713811345652751674.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, December 21, 2011 02:32:30 David Miller wrote:
> From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> Date: Tue, 20 Dec 2011 18:38:24 +0800
> 
> > The long line was introduced with b26e478f8f.
> > 
> > Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> 
> I'm not applying this.
> 
> I tell people to make sure arguments line up correctly to the
> openning parenthesis on the previous line, and that is what is
> happening here.

I am not against lining up the arguments but what about checkpatch ? Are we 
going to ignore the complaints or is this line limit about to be changed ?

Cheers,
Marek
