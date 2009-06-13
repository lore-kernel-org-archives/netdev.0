From: Maxim Osipov <maxim.osipov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Sat, 13 Jun 2009 09:37:34 +0400
Message-ID: <6097c490906122237l2be1836dsd30c3160f1a15ae8@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <9e4733910906122021k4568df6rd80fb915b64ac12@mail.gmail.com>
Reply-To: maxim-OiolBBqRjXA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9e4733910906122021k4568df6rd80fb915b64ac12-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 13, 2009 at 7:21 AM, Jon Smirl<jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
> Eremin-Solenikov<dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Hi,
>>
>> As a part of research activities the Embedded Systems - Open Platform Group
>> from Siemens Corporate Technology we are working on adding support for
>> the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our current
>> implementation is neither certified nor even feature complete. However
>> we'd like to present current state of our patchset to the Linux developers
>> community to gain comments, fixes, ideas, etc. This is not yet a pull request,
>> but more like an RFC.
>>
>
> The Zigbee alliance requires a minimum of $3,500/yr from any company
> making a product based on the spec. How are you going to reconcile
> this requirement with the GPL? They exempt non-commercial users but
> the GPL doesn't allow code to be free for one purpose and pay for
> another.
>

For now, we do not release any ZigBee implementation. BTW - could you
refer to particular clause of GPL, which doesn't allow user to pay for
code?

Regards,
Maxim
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
