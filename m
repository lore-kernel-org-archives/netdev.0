From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Fix multicast list setup in fec_restart().
Date: Thu, 27 Jun 2013 14:21:37 -0300
Message-ID: <CAOMZO5Cs9KfWGL-4HTF+rntzg1BE6L84vO67DL7qA+_eFJji-g@mail.gmail.com>
References: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
	<CAOMZO5CyK9S-Wmm+ihBeMCaDBJyxBb-vSQjzZiKrmz74mb=vDw@mail.gmail.com>
	<C2B6127F-2C6D-49ED-9E45-5FEE9CC1BCE4@theobroma-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Christoph_M=C3=BCllner?=
	<christoph.muellner@theobroma-systems.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C2B6127F-2C6D-49ED-9E45-5FEE9CC1BCE4@theobroma-systems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 27, 2013 at 2:14 PM, Christoph M=C3=BCllner
<christoph.muellner@theobroma-systems.com> wrote:

> Is updated in the attached patch.
> Thank you for the feedback!

Looks good.  Some suggestions:

- Mark the patch as the second version:
Subject: [PATCH v2] net: fec: Fix multicast list setup in fec_restart()=
=2E

- Add a comment below the --- line explaining what you changed in v2.

Something like:

---
Changes since v1:
- Adapt the comment to the code change

- Then re-send it via git send-email to the list instead of sending it
via attachment.

Thanks,

=46abio Estevam
