From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Wed, 13 Jul 2016 09:53:35 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391FC336@DFRE01.ent.ti.com>
References: <20160628104305.4533-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Hahn, Maital" <maitalm@ti.com>, Eliad Peller <eliad@wizery.com>,
	"Mishol, Guy" <guym@ti.com>,
	Johannes Berg <johannes.berg@intel.com>,
	"Arik Nemtsov" <arik@wizery.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628104305.4533-1-yanivma@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 13:41:35, Machani, Yaniv wrote:
> Guy; Johannes Berg; Arik Nemtsov; linux-wireless@vger.kernel.org; 
> netdev@vger.kernel.org
> Subject: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for 
> wl8
> 
> From: Maital Hahn <maitalm@ti.com>
> 
> 1. Added support for interface and role of mesh type.
> 2. Enabled enable/start of mesh-point role,
>    and opening and closing a connection with a mesh peer.
> 3. Added multirole combination of mesh and ap
>    under the same limits of dual ap mode.
> 4. Add support for 'sta_rc_update' opcode for mesh IF.
>    The 'sta_rc_update' opcode is being used in mesh_plink.c.
> Add support in wlcore to handle this opcode correctly for mesh (as 
> opposed to current implementation that handles STA only).
> 5. Bumped the firmware version to support new Mesh functionality
> 
> Signed-off-by: Maital Hahn <maitalm@ti.com>
> Signed-off-by: Yaniv Machani <yanivma@ti.com>
> ---

Any comments on this patch ?
Can this be pulled ?

Thanks,
Yaniv
