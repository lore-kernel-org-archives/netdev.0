From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Thu, 28 Sep 2006 12:33:32 -0400
Message-ID: <00c401c6e31b$d75c9970$4a580e98@ncsu2cc0c3fa00>
References: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00> <4514D590.9010201@nuim.ie> <56271.66.57.32.78.1158997517.squirrel@webmail.ncsu.edu> <aa7d2c6d0609271620h74a5cffxae22fd46daaa3f29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: "Douglas Leith" <doug.leith@nuim.ie>, <netdev@vger.kernel.org>,
	<floyd@icsi.berkeley.edu>, <lisongxu@gmail.com>,
	<end2end-interest@postel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni05mr.unity.ncsu.edu ([152.1.224.164]:32129 "EHLO
	uni05mr.unity.ncsu.edu") by vger.kernel.org with ESMTP
	id S932519AbWI1QeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 12:34:00 -0400
To: <l.andrew@ieee.org>, <rhee@ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sure. I don't mind doing this test. I am currently working with Doug Leith 
to get to the bottom of this difference. So when we get to the PFLDnet, we 
should have some more findings on this. But I am up for this challenge.

----- Original Message ----- 
From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
To: <rhee@ncsu.edu>
Cc: "Douglas Leith" <doug.leith@nuim.ie>; <netdev@vger.kernel.org>; 
<floyd@icsi.berkeley.edu>; <lisongxu@gmail.com>; "Injong Rhee" 
<rhee@eos.ncsu.edu>; <end2end-interest@postel.org>
Sent: Wednesday, September 27, 2006 7:20 PM
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc


> Greetings all,
>
> On 23/09/06, rhee@ncsu.edu <rhee@ncsu.edu> wrote:
>> Just i was pondering why we got different results and try to see if we 
>> can
>> come to some understanding on this different results we got. Who knows we
>> together might run into some fundamental research issues regarding
>> testing.
>
> Since many interested parties will be around LA for PFLDnet, how about
> getting together after that (Friday 9 Feb) to re-run some of the
> disputed tests on one set of hardware, with everyone present to debate
> the results?
>
> You're all welcome to come to Caltech to do the testing.  We can
> provide a few servers, dummynets and Gigabit switches.  Everyone is
> welcome to bring their scripts, and any other hardware they need.
>
> If there is interest, we could also have things like a round-table
> discussion of the benefits of testing with different file-length
> distributions (like long lived flows to understand what is happening
> vs a range of flows to test suitability for deployment), and the
> benefits of repeating other people's tests vs testing in as many
> scenarios as possible.
>
> Who is interested in coming?
>
> Cheers,
> Lachlan
>
> -- 
> Lachlan Andrew  Dept of Computer Science, Caltech
> 1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
> Phone: +1 (626) 395-8820    Fax: +1 (626) 568-3603
> 

