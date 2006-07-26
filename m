From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/24] RT2x00: Style fix
Date: Wed, 26 Jul 2006 19:04:30 +0200
Message-ID: <200607261904.30483.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932287AbWGZRHV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:21 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:20 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Coding style fix.
* Reduce the amount of tabs in the code
* Put Place function return type and function name on a single line
* Replace 'u8 char counter' with 'unsigned int i'
* Place '&&', '||' and '|' on the end of a line, instead of at the start.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/01_rt2x00_style.diff
