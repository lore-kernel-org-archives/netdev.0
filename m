From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] change format of LSM hooks
Date: Tue, 15 Oct 2002 17:03:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.170306.46455933.davem@redhat.com>
References: <20021015.131037.96602290.davem@redhat.com>
	<20021015202828.GG15864@kroah.com>
	<20021016000706.GI16966@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: greg@kroah.com
In-Reply-To: <20021016000706.GI16966@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Greg KH <greg@kroah.com>
   Date: Tue, 15 Oct 2002 17:07:06 -0700

   David, does something like this look acceptable?
   
Yes.

   which I hope are a bit more to your liking :)

It is :-)

   The extra #includes are needed as some files were getting
   security.h picked up from shed.h in the past.
   
Ok, I was about to ask about that.

Franks a lot,
David S. Miller
davem@redhat.com
