From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH nf-next v8 1/8] netfilter: Remove IP_CT_NEW_REPLY definition.
Date: Thu, 10 Mar 2016 11:16:48 +0200
Message-ID: <CAJ3xEMjEhfGBL9ts-vMMShEzyN+hN2mQL1oYNY2PmFyNw-npsQ@mail.gmail.com>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 9, 2016 at 2:24 AM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Remove the definition of IP_CT_NEW_REPLY from the kernel as it does
> not make sense.  This allows the definition of IP_CT_NUMBER to be
> simplified as well.

I just realized that after V7 you stopped sending cover letter (patch 0/N)
with this series.

Maybe you send it and this misses the list? we need to be able to see
differences from earlier versions.

Or.
