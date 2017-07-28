From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: refcount_t + (resend to wider audience)
Date: Fri, 28 Jul 2017 23:23:49 +0200
Message-ID: <20170728212349.GA11564@lunn.ch>
References: <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
 <20170728174117.GL2132@lunn.ch>
 <48b0c119-5277-1eca-d5d6-f2539ad3a7e8@android.com>
 <20170728.123139.1354715651678675641.davem@davemloft.net>
 <0eba17bc-218e-c45c-5a49-9313126cd018@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        stable@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0eba17bc-218e-c45c-5a49-9313126cd018@android.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please, guidance on where I can go from here.

Hi Mark

Real fixes will be accepted. So check if there are any refcount fixes
which are not in stable. If so, ask for the fix to be added to stable.

A fix should be independent of the infrastructure used to find there
is an issue.

   Andrew
