From: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Subject: Re: [PATCH] mac80211: fix build warning
Date: Mon, 25 Jun 2012 12:33:51 -0300
Message-ID: <CAAAP30EaW67e_w0k0W5qasaFfccfn0pDtqdHQB+-hesEbJwOLQ@mail.gmail.com>
References: <1340637550-12669-1-git-send-email-aletes.xgr@gmail.com>
	<CAD2nsn08gkYJnyYfqyZT8VX-bFPgDVZPgVSHE_QBEuXj5aEWMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mohammed Shafi <shafi.wireless@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD2nsn08gkYJnyYfqyZT8VX-bFPgDVZPgVSHE_QBEuXj5aEWMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2012 at 12:31 PM, Mohammed Shafi
<shafi.wireless@gmail.com> wrote:
> Hi,
>
> On Mon, Jun 25, 2012 at 8:49 PM, Alexandre Pereira da Silva
> <aletes.xgr@gmail.com> wrote:
>> Fix:
>> net/mac80211/mlme.c: In function 'ieee80211_prep_connection':
>> net/mac80211/mlme.c:3035:19: warning: 'sta' may be used uninitialized in
>> this function
>>
>> Initialize sta to NULL
>
> i think already fixed by and there in wireless-testing
> http://www.spinics.net/lists/linux-wireless/msg92385.html

Ok, thanks for pointing that out.
