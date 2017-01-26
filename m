From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] mac80211: use helper function to access
 ieee802_1d_to_ac[]
Date: Thu, 26 Jan 2017 09:51:24 +0100
Message-ID: <1485420684.11038.2.camel@sipsolutions.net>
References: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com>
         (sfid-20170124_164227_980319_47DCDD4D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Amadeusz =?UTF-8?Q?S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com> (sfid-20170124_164227_980319_47DCDD4D)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-01-24 at 16:42 +0100, Amadeusz Sławiński wrote:
> cleanup patch to make use of ieee80211_ac_from_tid() to retrieve ac
> from
> ieee802_1d_to_ac[]

Applied.

johannes
