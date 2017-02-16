From: Peter Korsgaard <peter-+2lRwdCCLRT2eFz/2MeuCQ@public.gmane.org>
Subject: Re: [PATCH 03/21] net-next: stmmac: add optional setup function
Date: Thu, 16 Feb 2017 21:38:33 +0100
Message-ID: <87mvdlg9bq.fsf@dell.be.48ers.dk>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
	<20170216124859.14346-4-clabbe.montjoie@gmail.com>
Reply-To: jacmet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,  robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,  mark.rutland-5wv7dgnIgG8@public.gmane.org,  maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,  wens-jdAy2FN1RRM@public.gmane.org,  linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,  catalin.marinas-5wv7dgnIgG8@public.gmane.org,  will.deacon-5wv7dgnIgG8@public.gmane.org,  alexandre.torgue-qxv4g6HH51o@public.gmane.org,  netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,  linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDKONJFYSUEBBTE3TDCQKGQEVG63W3Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: Peter Korsgaard <jacmet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
In-Reply-To: <20170216124859.14346-4-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Corentin
	Labbe's message of "Thu, 16 Feb 2017 13:48:41 +0100")
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

>>>>> "Corentin" == Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

 > Instead of ading more ifthen login for adding a new mac_device_info

s/login/logic/

-- 
Bye, Peter Korsgaard
