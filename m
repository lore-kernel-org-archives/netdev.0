From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Mon, 18 Jul 2016 19:33:47 +0000 (UTC)
Message-ID: <20160718193347.4F5CD602A9@smtp.codeaurora.org>
References: <20160628104305.4533-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>,
	Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Guy Mishol <guym-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160628104305.4533-1-yanivma-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org> wrote:
> From: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> 
> 1. Added support for interface and role of mesh type.
> 2. Enabled enable/start of mesh-point role,
>    and opening and closing a connection with a mesh peer.
> 3. Added multirole combination of mesh and ap
>    under the same limits of dual ap mode.
> 4. Add support for 'sta_rc_update' opcode for mesh IF.
>    The 'sta_rc_update' opcode is being used in mesh_plink.c.
> Add support in wlcore to handle this opcode correctly for mesh
> (as opposed to current implementation that handles STA only).
> 5. Bumped the firmware version to support new Mesh functionality
> 
> Signed-off-by: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> Signed-off-by: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

c0174ee28003 wlcore/wl18xx: mesh: added initial mesh support for wl8

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9202707/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
