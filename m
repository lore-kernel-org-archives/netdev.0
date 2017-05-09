From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: qca_debug: Reduce function calls for sequence output in
 qcaspi_info_show()
Date: Tue, 9 May 2017 09:57:57 +0200
Message-ID: <f9fef8a0-13c2-8dae-cb2a-7d39491e47f4@users.sourceforge.net>
References: <9932ee63-f766-49ce-d760-9a0bd06f0657@users.sourceforge.net>
 <290d2473-73bd-70db-b6ef-c50331812f31@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <290d2473-73bd-70db-b6ef-c50331812f31@i2se.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The only benefit is a little bit higher performance.

I would prefer such a small code reduction. I am not so concerned
about an other readability impression at this place.


> But for debugfs this won't be necessary.

I would appreciate also another improvement there.

Regards,
Markus
