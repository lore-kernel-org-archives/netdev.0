From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 17:49:00 -0700
Message-ID: <200708031749.00900.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <170fa0d20708022109s60ebb85aqe68ec1033634ef27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "Mike Snitzer" <snitzer@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762248AbXHDAtS@vger.kernel.org>
In-Reply-To: <170fa0d20708022109s60ebb85aqe68ec1033634ef27@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mike,

On Thursday 02 August 2007 21:09, Mike Snitzer wrote:
> But NBD's synchronous nature is actually an asset when coupled with
> MD raid1 as it provides guarantees that the data has _really_ been
> mirrored remotely.

And bio completion doesn't?

Regards,

Daniel
