From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/2] qed: Add support for hardware offloaded
 FCoE.
Date: Wed, 18 Jan 2017 17:21:26 +0100
Message-ID: <b09401be-3103-6a37-f203-4c696b9cac9a@suse.de>
References: <1484596437-27637-1-git-send-email-chad.dupuis@cavium.com>
 <1484596437-27637-2-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1484596437-27637-2-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 01/16/2017 08:53 PM, Dupuis, Chad wrote:
> From: Arun Easi <arun.easi-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> =

> This adds the backbone required for the various HW initalizations
> which are necessary for the FCoE driver (qedf) for QLogic FastLinQ
> 4xxxx line of adapters - FW notification, resource initializations, etc.
> =

> Signed-off-by: Arun Easi <arun.easi-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yuval Mintz <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---

Reviewed-by: Hannes Reinecke <hare-IBi9RG/b67k@public.gmane.org>

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
