From: "Benjamin Thery" <ben.thery-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/6] preparations to enable netdevice notifiers inside a
	namespace (resend)
Date: Thu, 31 Jan 2008 17:47:22 +0100
Message-ID: <939d53060801310847y31c4542do271edd48e44745c7@mail.gmail.com>
References: <47A1B835.7050600@sw.ru> <47A1E21C.40909@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
To: "Daniel Lezcano" <daniel.lezcano-GANU6spQydw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47A1E21C.40909-GANU6spQydw@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Jan 31, 2008 3:58 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> Denis V. Lunev wrote:
> > Here are some preparations and cleanups to enable network device/inet
> > address notifiers inside a namespace.
> >
> > This set of patches has been originally sent last Friday. One cleanup
> > patch from the original series is dropped as wrong, thanks to Daniel
> > Lezcano.
>
> Can you explain please.


I think Denis refers to the patch called "3/7 Prohibit assignment of
0.0.0.0as interface address." ,
he dropped because it was inappropriate, no?

-- Benjamin

--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
