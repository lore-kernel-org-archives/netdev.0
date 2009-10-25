From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Sun, 25 Oct 2009 10:45:59 +0200
Message-ID: <4AE41047.6020904@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-9-git-send-email-gilad@codefidence.com> <4ADED6FA.2030502@gmail.com> <4ADEE119.7020803@codefidence.com> <4ADF616B.1090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:35023 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbZJYIqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 04:46:00 -0400
In-Reply-To: <4ADF616B.1090405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> I have no issue with leaving those, if everyone thinks we're better off.
>>
>> BTW, while we're talking about OS envy, I do believe that Windows do let
>> you specify on a per route basis. Not that this is really a good 
>> ground for
>> technical decision, but still... :-)
>>
> I'm not concerned with "envy", I'm concerned with training operators, and
> consistency across platforms.
>
> I'm in favor of per route configuration, it seems reasonably clean, as
> long as it's done consistently with other systems.  I don't permit 
> Windows
> systems to be used here (except under controlled security 
> circumstances), so
> I'm not familiar with their configuration.  However, doing things 
> similarly
> across platforms will ease documentation and training.
>
I have no objection leaving the current sysctl as is. Personally, I 
think it's useless when you have route level options but I don't care 
all that much.

The powers that be are more then welcome to ACK the first 7 patches and 
NACK the documentation of the sysctl as deprecated. :-)

Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

