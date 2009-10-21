From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Wed, 21 Oct 2009 15:30:51 -0400
Message-ID: <4ADF616B.1090405@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-9-git-send-email-gilad@codefidence.com> <4ADED6FA.2030502@gmail.com> <4ADEE119.7020803@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:36179 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbZJUTax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 15:30:53 -0400
Received: by mail-fx0-f218.google.com with SMTP id 18so8151435fxm.37
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 12:30:58 -0700 (PDT)
In-Reply-To: <4ADEE119.7020803@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> I have no issue with leaving those, if everyone thinks we're better off.
> 
> BTW, while we're talking about OS envy, I do believe that Windows do let
> you specify on a per route basis. Not that this is really a good ground for
> technical decision, but still... :-)
> 
I'm not concerned with "envy", I'm concerned with training operators, and
consistency across platforms.

I'm in favor of per route configuration, it seems reasonably clean, as
long as it's done consistently with other systems.  I don't permit Windows
systems to be used here (except under controlled security circumstances), so
I'm not familiar with their configuration.  However, doing things similarly
across platforms will ease documentation and training.

