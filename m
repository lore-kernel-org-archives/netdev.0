From: Andev <debiandev@gmail.com>
Subject: Re: [PATCH resend] rsi: Fix a potential memory leak in rsi_set_channel()
Date: Thu, 10 Apr 2014 16:01:35 -0400
Message-ID: <CAJUuVQ7xgRLDzwojDCdb3yhTm3HygypMLXyaRiErnVveNVz+sQ@mail.gmail.com>
References: <20140410203146.767149e7@spike>
	<CAJUuVQ5KW3v0DgwotDMow=rBvxoZKfYYD2misXbsMD6c1UaShw@mail.gmail.com>
	<20140410195402.GA17308@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christian Engelmayer <cengelma@gmx.at>, linville@tuxdriver.com,
	fariyaf@gmail.com, dan.carpenter@oracle.com, joe@perches.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Greg Kroah-Hartman <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140410195402.GA17308@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 10, 2014 at 3:54 PM, Greg Kroah-Hartman <greg@kroah.com> wrote:
> On Thu, Apr 10, 2014 at 03:46:12PM -0400, Andev wrote:
>> Adding Greg KH,
>
> Why do I care about this?
>

I am not sure if this needs to be applied to stable too. Should I have
cc'ed stable@?

-- 
Pratapa Rudra
