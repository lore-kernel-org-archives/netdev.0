From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH] openvswitch: Remove unnecessary newlines from OVS_NLERR uses
Date: Fri, 11 Aug 2017 09:16:24 -0700
Message-ID: <CAPWQB7FFUAR5civcRDM3sx65wuJXrb+T3fx5oQLX2S32X=kb2A@mail.gmail.com>
References: <72f936a314a54a7957afdeb19e3d019c8c1dabea.1502450609.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <72f936a314a54a7957afdeb19e3d019c8c1dabea.1502450609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 August 2017 at 04:26, Joe Perches <joe@perches.com> wrote:
> OVS_NLERR already adds a newline so these just add blank
> lines to the logging.
>
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Joe Stringer <joe@ovn.org>
